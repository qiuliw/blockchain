package models

import (
	"crypto/x509"
	"fmt"
	"os"
	"path"
	"sync"
	"time"

	"github.com/astaxie/beego"
	"github.com/hyperledger/fabric-gateway/pkg/client"
	"github.com/hyperledger/fabric-gateway/pkg/hash"
	"github.com/hyperledger/fabric-gateway/pkg/identity"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

var (
	gatewayOnce sync.Once
	gatewayInst *client.Gateway
	gatewayErr  error
)

func gateway() (*client.Gateway, error) {
	gatewayOnce.Do(func() {
		conn, err := newGrpcConnection()
		if err != nil {
			gatewayErr = err
			return
		}

		id, err := newIdentity()
		if err != nil {
			gatewayErr = err
			return
		}

		sign, err := newSign()
		if err != nil {
			gatewayErr = err
			return
		}

		gatewayInst, gatewayErr = client.Connect(
			id,
			client.WithSign(sign),
			client.WithHash(hash.SHA256),
			client.WithClientConnection(conn),
			client.WithEvaluateTimeout(30*time.Second),
			client.WithEndorseTimeout(60*time.Second),
			client.WithSubmitTimeout(30*time.Second),
			client.WithCommitStatusTimeout(2*time.Minute),
		)
	})
	return gatewayInst, gatewayErr
}

func channelID() string {
	return beego.AppConfig.String("channel_id")
}

func fabricConfig(key, fallback string) string {
	if v := beego.AppConfig.String(key); v != "" {
		return v
	}
	return fallback
}

func contract(chaincodeID string) (*client.Contract, error) {
	gw, err := gateway()
	if err != nil {
		return nil, err
	}
	return gw.GetNetwork(channelID()).GetContract(chaincodeID), nil
}

func toStringArgs(args [][]byte) []string {
	out := make([]string, len(args))
	for i, arg := range args {
		out[i] = string(arg)
	}
	return out
}

func Query(chaincodeID, fcn string, args [][]byte) ([]byte, error) {
	c, err := contract(chaincodeID)
	if err != nil {
		return nil, err
	}
	return c.EvaluateTransaction(fcn, toStringArgs(args)...)
}

func Invoke(chaincodeID, fcn string, args [][]byte) ([]byte, error) {
	c, err := contract(chaincodeID)
	if err != nil {
		return nil, err
	}
	return c.SubmitTransaction(fcn, toStringArgs(args)...)
}

func newGrpcConnection() (*grpc.ClientConn, error) {
	tlsCertPath := fabricConfig("fabric_tls_cert", "/app/fabric/peer-tls/ca.crt")
	gatewayPeer := fabricConfig("fabric_gateway_peer", "peer0.org1.example.com")
	peerEndpoint := fabricConfig("fabric_peer_endpoint", "dns:///host.minikube.internal:7051")

	certificatePEM, err := os.ReadFile(tlsCertPath)
	if err != nil {
		return nil, fmt.Errorf("read TLS certificate %s: %w", tlsCertPath, err)
	}

	certificate, err := identity.CertificateFromPEM(certificatePEM)
	if err != nil {
		return nil, err
	}

	certPool := x509.NewCertPool()
	certPool.AddCert(certificate)
	transportCredentials := credentials.NewClientTLSFromCert(certPool, gatewayPeer)

	return grpc.NewClient(peerEndpoint, grpc.WithTransportCredentials(transportCredentials))
}

func newIdentity() (*identity.X509Identity, error) {
	mspID := fabricConfig("fabric_msp_id", "Org1MSP")
	certDir := fabricConfig("fabric_cert_dir", "/app/fabric/msp/signcerts")

	certificatePEM, err := readFirstFile(certDir)
	if err != nil {
		return nil, fmt.Errorf("read certificate from %s: %w", certDir, err)
	}

	certificate, err := identity.CertificateFromPEM(certificatePEM)
	if err != nil {
		return nil, err
	}

	return identity.NewX509Identity(mspID, certificate)
}

func newSign() (identity.Sign, error) {
	keyDir := fabricConfig("fabric_key_dir", "/app/fabric/msp/keystore")

	privateKeyPEM, err := readFirstFile(keyDir)
	if err != nil {
		return nil, fmt.Errorf("read private key from %s: %w", keyDir, err)
	}

	privateKey, err := identity.PrivateKeyFromPEM(privateKeyPEM)
	if err != nil {
		return nil, err
	}

	return identity.NewPrivateKeySign(privateKey)
}

func readFirstFile(dirPath string) ([]byte, error) {
	dir, err := os.Open(dirPath)
	if err != nil {
		return nil, err
	}
	defer dir.Close()

	names, err := dir.Readdirnames(1)
	if err != nil {
		return nil, err
	}

	return os.ReadFile(path.Join(dirPath, names[0]))
}
