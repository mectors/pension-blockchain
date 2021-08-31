#!/bin/zsh
investgbpaccount=$(cat pension-conf.json | jq -r '.invmgrgbpaccount')
investfundaccount=$(cat pension-conf.json | jq -r '.invmgrfundaccount')
for i in $(seq 5); do employeeaccount[$i]=$(cat pension-conf.json | jq -r '.employeegbpaccount'$i); done
for i in $(seq 5); do employeefundaccount[$i]=$(cat pension-conf.json | jq -r '.employeefundaccount'$i); done
for i in $(seq 5); do multisig[$i]=$(cat pension-conf.json | jq -r '.multisigpensionenerprise'$i);done
gbp=$(cat pension-conf.json | jq -r '.gbptoken')
ftoken=$(cat pension-conf.json | jq -r '.fundtoken')
amount=20
echo Invest $amount GBP $gbp from employees into 40 fund tokens $ftoken
for i in $(seq 5); do echo employee $i GBP:;spl-token balance --address $employeeaccount[$i];echo fund:;spl-token balance --address $employeefundaccount[$i];done
for i in $(seq 5); do spl-token transfer $gbp $amount $investgbpaccount --from $employeeaccount[$i] --owner $multisig[$i] --multisig-signer signer-pensionmgr.json; done
echo Investment manager converts GBP into fund tokens
spl-token mint $ftoken 200 $investfundaccount --owner signer-investmentmgr.json
echo transfer investment tokens from investment mgr to employees
for i in $(seq 5); do spl-token transfer $ftoken 40 $employeefundaccount[$i] --from $investfundaccount --owner signer-investmentmgr.json;done
for i in $(seq 5); do echo employee $i GBP:;spl-token balance --address $employeeaccount[$i];echo fund:;spl-token balance --address $employeefundaccount[$i];done
