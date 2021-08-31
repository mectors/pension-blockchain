#!/bin/zsh
bankaccount=$(cat pension-conf.json | jq -r '.bankaccount')
enterpriseaccount=$(cat pension-conf.json | jq -r '.enterpriseaccount')
for i in $(seq 5); do employeeaccount[$i]=$(cat pension-conf.json | jq -r '.employeegbpaccount'$i); done
gbp=$(cat pension-conf.json | jq -r '.gbptoken')
amount=100
echo transfer $amount from bank into GBP tokens
spl-token mint $gbp $amount $bankaccount --owner signer-bank.json
echo transfer GBP tokens from bank to enterprise
spl-token transfer $gbp $amount $enterpriseaccount --from $bankaccount --owner signer-bank.json
echo transfer GBP tokens from enterprise to all individual employees
echo employee each gets 1/5
for i in $(seq 5); do spl-token transfer $gbp 20 ${employeeaccount[$i]} --from $enterpriseaccount --owner signer-enterprise.json; done

