How to apply blockchain to pension?

This is a high-level prototype [do not use in production!]. Before starting install:

jq
solana
spl-token

Run one time ./setup.sh which will create:

1) A bank which converts funds from an enterprise into GBP tokens.
2) An enterprise which holds an enterprise GBP token account and has 5 employees
3) A pension manager which together with the enterprise and the employee owns a GBP token account for each of the 5 employees of the enterprise.
4) An investment manager which holds a GBP token account and a fund account and swaps GBP tokens for investment funds tokens at a 1 to 2 rate.
5) 5 employees who get GBP tokens from their enterprise [pension contributions] which through the investment manager are converted into fund tokens and put into their fund account. Since this is a 2/2 multi-sig, they cannot withdraw the funds unless the pension manager agrees.

To ask the bank for 100 GBP into the enterprise account and to transfer 5 times 20 GBP into each employees account run ./enterprise.sh

To invest the 20 GBP into 40 fund tokens for each of the employees run ./employee.sh
