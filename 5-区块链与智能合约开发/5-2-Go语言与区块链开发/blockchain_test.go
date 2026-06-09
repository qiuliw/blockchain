package main

import (
	"os"
	"testing"
)

func TestFindUTXO(t *testing.T) {
	_ = os.Remove(blockChainDB)
	_ = os.Remove(walletFile)

	wallets := NewWallets()
	miner := wallets.CreateWallet()
	alice := wallets.CreateWallet()

	bc := NewBlockchain(miner)
	defer func() {
		bc.db.Close()
		_ = os.Remove(blockChainDB)
		_ = os.Remove(walletFile)
	}()

	utxos := bc.FindUTXO(miner)
	if len(utxos) != 1 {
		t.Fatalf("expected 1 UTXO for miner, got %d", len(utxos))
	}
	if utxos[0].Value != reward {
		t.Fatalf("expected miner UTXO value %d, got %d", reward, utxos[0].Value)
	}

	wallet := wallets.GetWallet(miner)
	tx := NewUTXOTransaction(wallet, alice, 5, bc)
	if tx == nil {
		t.Fatal("failed to create transaction")
	}

	bc.AddBlock([]*Transaction{tx})

	minerUTXOs := bc.FindUTXO(miner)
	if len(minerUTXOs) != 1 {
		t.Fatalf("expected 1 UTXO for miner after spend, got %d", len(minerUTXOs))
	}
	if minerUTXOs[0].Value != reward-5 {
		t.Fatalf("expected miner UTXO value %d after spend, got %d", reward-5, minerUTXOs[0].Value)
	}

	aliceUTXOs := bc.FindUTXO(alice)
	if len(aliceUTXOs) != 1 {
		t.Fatalf("expected 1 UTXO for alice, got %d", len(aliceUTXOs))
	}
	if aliceUTXOs[0].Value != 5 {
		t.Fatalf("expected alice UTXO value 5, got %d", aliceUTXOs[0].Value)
	}
}

func TestNewTransaction(t *testing.T) {
	_ = os.Remove(blockChainDB)
	_ = os.Remove(walletFile)

	wallets := NewWallets()
	miner := wallets.CreateWallet()
	alice := wallets.CreateWallet()

	bc := NewBlockchain(miner)
	defer func() {
		bc.db.Close()
		_ = os.Remove(blockChainDB)
		_ = os.Remove(walletFile)
	}()

	wallet := wallets.GetWallet(miner)
	tx := NewUTXOTransaction(wallet, alice, 5, bc)
	if tx == nil {
		t.Fatal("expected transaction, got nil")
	}

	bc.AddBlock([]*Transaction{tx})

	minerUTXOs := bc.FindUTXO(miner)
	if len(minerUTXOs) != 1 {
		t.Fatalf("expected 1 UTXO for miner after transfer, got %d", len(minerUTXOs))
	}
	if minerUTXOs[0].Value != reward-5 {
		t.Fatalf("expected miner UTXO value %d after transfer, got %d", reward-5, minerUTXOs[0].Value)
	}

	aliceUTXOs := bc.FindUTXO(alice)
	if len(aliceUTXOs) != 1 {
		t.Fatalf("expected 1 UTXO for alice after transfer, got %d", len(aliceUTXOs))
	}
	if aliceUTXOs[0].Value != 5 {
		t.Fatalf("expected alice UTXO value 5, got %d", aliceUTXOs[0].Value)
	}
}
