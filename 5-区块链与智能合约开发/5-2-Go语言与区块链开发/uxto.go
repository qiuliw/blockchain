package main

// 维护可用 uxto

type UTXORecord struct {
	TXID   []byte
	Index  int64
	Output TXOutput
}

// 查找所有可用 UTXO
func (bc *BlockChain) FindUTXORecords(address string) []UTXORecord {

	var records []UTXORecord

	spentOutputs := make(map[string]map[int64]bool)

	it := bc.NewIterator()

	for {

		block := it.Next() // 区块逆序

		// 逆 正 同时判断，只input 会遗漏前区块。
		// 正，逆 同时判断，只 output 会遗漏后区块。
		// 只正正，逆逆，可以只判断一个

		for i := len(block.Transactions) - 1; i >= 0; i-- { // 交易逆序

			tx := block.Transactions[i]

			txID := string(tx.TXID)

			// Output
			for idx, out := range tx.TXOutputs {

				if out.PubKeyHash != address {
					continue
				}

				spent := false

				if spentOutputs[txID] != nil {
					spent = spentOutputs[txID][int64(idx)]
				}

				if spent {
					continue
				}

				records = append(records, UTXORecord{
					TXID:   tx.TXID,
					Index:  int64(idx),
					Output: out,
				})
			}

			if tx.IsCoinbase() {
				continue
			}

			// Input
			for _, in := range tx.TXInputs {

				refTxID := string(in.TXID)

				if spentOutputs[refTxID] == nil {
					spentOutputs[refTxID] =
						make(map[int64]bool)
				}

				spentOutputs[refTxID][in.Index] = true
			}
		}

		if len(block.PrevHash) == 0 {
			break
		}
	}

	return records
}

// 获取够用的 UTXOs集合
func (bc *BlockChain) FindNeedUTXOs(
	address string,
	amount int64,
) ([]UTXORecord, int64) {

	records := bc.FindUTXORecords(address)

	var result []UTXORecord
	var total int64

	for _, record := range records {

		result = append(result, record)

		total += record.Output.Value

		if total >= amount {
			return result, total
		}
	}

	return nil, total
}

// 对所有UTXO求和
func (bc *BlockChain) GetBalance(address string) int64 {

	records := bc.FindUTXORecords(address)

	var balance int64

	for _, record := range records {
		balance += record.Output.Value
	}

	return balance
}
