package models

import (
	"errors"
	"sync"

	"github.com/astaxie/beego"
	fab "github.com/hyperledger/fabric-sdk-go/api/apifabclient"
	"github.com/hyperledger/fabric-sdk-go/api/apitxn"
	"github.com/hyperledger/fabric-sdk-go/def/fabapi"
	clientImpl "github.com/hyperledger/fabric-sdk-go/pkg/fabric-client"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabric-client/orderer"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabric-client/peer"
)

var (
	sdkOnce sync.Once
	sdkInst *fabapi.FabricSDK
	sdkErr  error
)

func sdk() (*fabapi.FabricSDK, error) {
	sdkOnce.Do(func() {
		sdkInst, sdkErr = fabapi.NewSDK(fabapi.Options{
			ConfigFile: beego.AppConfig.String("sdk_config"),
		})
	})
	return sdkInst, sdkErr
}

func channelID() string {
	return beego.AppConfig.String("channel_id")
}

func userID() string {
	return beego.AppConfig.String("user_id")
}

func Query(chaincodeID, fcn string, args [][]byte) ([]byte, error) {
	s, err := sdk()
	if err != nil {
		return nil, err
	}
	client, err := s.NewChannelClient(channelID(), userID())
	if err != nil {
		return nil, err
	}
	defer client.Close()
	return client.Query(apitxn.QueryRequest{ChaincodeID: chaincodeID, Fcn: fcn, Args: args})
}

func Invoke(chaincodeID, fcn string, args [][]byte) ([]byte, error) {
	s, err := sdk()
	if err != nil {
		return nil, err
	}
	return submitTx(s, chaincodeID, fcn, args)
}

func buildChannel(client fab.FabricClient, channelID string) (fab.Channel, error) {
	ch, err := client.NewChannel(channelID)
	if err != nil {
		return nil, err
	}

	orderers, err := client.Config().ChannelOrderers(channelID)
	if err != nil {
		return nil, err
	}
	for _, cfg := range orderers {
		o, err := orderer.NewOrdererFromConfig(&cfg, client.Config())
		if err != nil {
			return nil, err
		}
		if err = ch.AddOrderer(o); err != nil {
			return nil, err
		}
	}

	peers, err := client.Config().ChannelPeers(channelID)
	if err != nil {
		return nil, err
	}
	for _, p := range peers {
		node, err := peer.NewPeerFromConfig(&p.NetworkPeer, client.Config())
		if err != nil {
			return nil, err
		}
		if err = ch.AddPeer(node); err != nil {
			return nil, err
		}
	}
	return ch, nil
}

func submitTx(s *fabapi.FabricSDK, chaincodeID, fcn string, args [][]byte) ([]byte, error) {
	orgCfg, err := s.ConfigProvider().Client()
	if err != nil {
		return nil, err
	}
	session, err := s.NewPreEnrolledUserSession(orgCfg.Organization, userID())
	if err != nil {
		return nil, err
	}

	cfg := s.ConfigProvider()
	client := clientImpl.NewClient(cfg)
	client.SetCryptoSuite(s.CryptoSuiteProvider())
	client.SetStateStore(s.StateStoreProvider())
	client.SetUserContext(session.Identity())
	client.SetSigningManager(s.SigningManager())

	ch, err := buildChannel(client, channelID())
	if err != nil {
		return nil, err
	}

	discovery, err := s.DiscoveryProvider().NewDiscoveryService(channelID())
	if err != nil {
		return nil, err
	}
	selection, err := s.SelectionProvider().NewSelectionService(channelID())
	if err != nil {
		return nil, err
	}

	peerList, err := discovery.GetPeers()
	if err != nil {
		return nil, err
	}
	endorsers, err := selection.GetEndorsersForChaincode(peerList, chaincodeID)
	if err != nil {
		return nil, err
	}

	request := apitxn.ChaincodeInvokeRequest{
		ChaincodeID: chaincodeID,
		Fcn:         fcn,
		Args:        args,
		Targets:     peer.PeersToTxnProcessors(endorsers),
	}

	sender, ok := ch.(apitxn.ProposalSender)
	if !ok {
		return nil, errors.New("channel does not support transaction proposals")
	}
	resps, txID, err := sender.SendTransactionProposal(request)
	if err != nil {
		return nil, err
	}
	for _, v := range resps {
		if v.Err != nil {
			return nil, v.Err
		}
	}

	txSender, ok := ch.(apitxn.Sender)
	if !ok {
		return nil, errors.New("channel does not support transaction submit")
	}
	tx, err := txSender.CreateTransaction(resps)
	if err != nil {
		return nil, err
	}
	txResp, err := txSender.SendTransaction(tx)
	if err != nil {
		return nil, err
	}
	if txResp.Err != nil {
		return nil, txResp.Err
	}
	return []byte(txID.ID), nil
}
