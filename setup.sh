#!/bin/bash
echo Create bank, enterprise, pension manager, investment manager and employee
solana-keygen new --no-passphrase -so signer-bank.json
solana-keygen new --no-passphrase -so signer-enterprise.json
solana-keygen new --no-passphrase -so signer-pensionmgr.json
solana-keygen new --no-passphrase -so signer-investmentmgr.json
echo creating 5 employees
for i in $(seq 5); do solana-keygen new --no-passphrase -so "signer-employee${i}.json"; done
solana airdrop 100 signer-bank.json
solana airdrop 100 signer-enterprise.json
solana airdrop 100 signer-pensionmgr.json
solana airdrop 100 signer-investmentmgr.json
for i in $(seq 5); do solana airdrop 100 "signer-employee${i}.json"; done
bankkey=$(solana-keygen pubkey signer-bank.json)
enterprisekey=$(solana-keygen pubkey signer-enterprise.json)
pensionmgrkey=$(solana-keygen pubkey signer-pensionmgr.json)
investmentmgrkey=$(solana-keygen pubkey signer-investmentmgr.json)
for i in $(seq 5); do employeekey[$i]=$(solana-keygen pubkey signer-employee${i}.json); done
#multisigemplypension=$(spl-token create-multisig 2 $pensionmgrkey $employeekey --output json-compact | jq -r '.multisig')
#multisigpensionenter=$(spl-token create-multisig 1 $pensionmgrkey $enterprisekey --output json-compact | jq -r '.multisig')
for i in $(seq 5); do multisigemplypension[$i]=$(spl-token create-multisig 2 $pensionmgrkey ${employeekey[$i]} | grep -o 'multisig [^ ,]\+' | awk '{print($2)}'); done
echo Created multsig employee pension $multisigemplypension
for i in $(seq 5); do multisigpensionenter[$i]=$(spl-token create-multisig 1 $pensionmgrkey $enterprisekey ${employeekey[$i]} | grep -o 'multisig [^ ,]\+' | awk '{print($2)}'); done
echo Created multisig pension enterprise $multisigpensionenter
echo Create GBP token
token=$(spl-token create-token | grep -o 'token [^ ,]\+' | awk '{print($2)}')
echo Token identifier $token
echo Create fund token
ftoken=$(spl-token create-token | grep -o 'token [^ ,]\+' | awk '{print($2)}')
echo Token identifier $ftoken
echo Make bank account for GBP
bankaccount=$(spl-token create-account $token --owner signer-bank.json | grep -o 'account [^ ,]\+' | awk '{print($2)}')
echo Mint 1000 $token for $bankaccount with key $bankkey
spl-token authorize $token mint $bankkey
spl-token mint $token 1000 $bankaccount --owner signer-bank.json
echo Bank account is $bankaccount
echo Make enterprise account for GBP
enterpriseaccount=$(spl-token create-account $token --owner signer-enterprise.json | grep -o 'account [^ ,]\+' | awk '{print($2)}')
echo Enterpise account is $enterpriseaccount
echo Make employee GBP account 
for i in $(seq 5); do employeeaccount[$i]=$(spl-token create-account $token --owner ${multisigpensionenter[$i]} | grep -o 'account [^ ,]\+' | awk '{print($2)}'); done
echo Make employee fund account
for i in $(seq 5); do employeefundaccount[$i]=$(spl-token create-account $ftoken --owner ${multisigemplypension[$i]} | grep -o 'account [^ ,]\+' | awk '{print($2)}'); done
echo Employee fund account is $employeefundaccount1
echo Make investment manager accounts
fundaccount=$(spl-token create-account $ftoken --owner signer-investmentmgr.json | grep -o 'account [^ ,]\+' | awk '{print($2)}')
spl-token authorize $ftoken mint $investmentmgrkey 
spl-token mint $ftoken 5000 $fundaccount --owner signer-investmentmgr.json
echo investment mgr account is $fundaccount
fundgbpaccount=$(spl-token create-account $token --owner signer-investmentmgr.json | grep -o 'account [^ ,]\+' | awk '{print($2)}')
echo investment mgr gbp account is $fundgbpaccount
echo Writing pension-conf.json
printf '{\n  "fundtoken": "%s",\n  "enterpriseaccount": "%s",\n  "invmgrgbpaccount": "%s",\n  "invmgrfundaccount": "%s",\n  "bankaccount": "%s",\n  "bankkey": "%s",\n  "enterprisekey": "%s",\n  "pensionmgrkey": "%s",\n  "investmentmgrkey": "%s",\n' $ftoken $enterpriseaccount $fundgbpaccount $fundaccount $bankaccount $bankkey $enterprisekey $pensionmgrkey $investmentmgrkey > pension-conf.json
for i in $(seq 5); do printf '  "employeegbpaccount%s": "%s",\n' $i ${employeeaccount[$i]} >> pension-conf.json; done
for i in $(seq 5); do printf '  "employeefundaccount%s": "%s",\n' $i ${employeefundaccount[$i]} >> pension-conf.json; done
for i in $(seq 5); do printf '  "employeekey%s": "%s",\n' $i ${employeekey[$i]} >> pension-conf.json; done
for i in $(seq 5); do printf '  "multisigemplypension%s": "%s",\n' $i ${multisigemplypension[$i]} >> pension-conf.json; done   
for i in $(seq 5); do printf '  "multisigpensionenerprise%s": "%s",\n' $i ${multisigpensionenter[$i]} >> pension-conf.json; done
printf '  "gbptoken": "%s"\n}\n' $token >> pension-conf.json
