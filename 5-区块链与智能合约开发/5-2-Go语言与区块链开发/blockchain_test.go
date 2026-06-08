package main

import (
	"os"
	"testing"
)

func TestFindUTXOs(t *testing.T) {
	_ = os.Remove(blockChainDB)

	bc := NewBlockChain("miner")
	defer func() {
		bc.db.Close()
		_ = os.Remove(blockChainDB)
	}()

	utxos := bc.FindUTXOs("miner")
	if len(utxos) != 1 {
		t.Fatalf("expected 1 UTXO for miner, got %d", len(utxos))
	}
	if utxos[0].Value != reward {
		t.Fatalf("expected miner UTXO value %d, got %d", reward, utxos[0].Value)
	}

	genesisTX := NewCoinbaseTX("miner", genesisInfo)

	spendTx := &Transaction{
		TXInputs: []TXInput{
			{
				TXID:      genesisTX.TXID,
				Index:     0,
				Signature: "miner",
			},
		},
		TXOutputs: []TXOutput{
			{Value: 5, PubKeyHash: "alice"},
			{Value: reward - 5, PubKeyHash: "miner"},
		},
	}
	spendTx.TXID = spendTx.Hash()

	bc.AddBlock([]*Transaction{spendTx})

	minerUTXOs := bc.FindUTXOs("miner")
	if len(minerUTXOs) != 1 {
		t.Fatalf("expected 1 UTXO for miner after spend, got %d", len(minerUTXOs))
	}
	if minerUTXOs[0].Value != reward-5 {
		t.Fatalf("expected miner UTXO value %d after spend, got %d", reward-5, minerUTXOs[0].Value)
	}

	aliceUTXOs := bc.FindUTXOs("alice")
	if len(aliceUTXOs) != 1 {
		t.Fatalf("expected 1 UTXO for alice, got %d", len(aliceUTXOs))
	}
	if aliceUTXOs[0].Value != 5 {
		t.Fatalf("expected alice UTXO value 5, got %d", aliceUTXOs[0].Value)
	}
}
