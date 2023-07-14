//deployed on 0x04f04ab144b97daf33c0e4f602536e780041af3bceda0ea1c3691b567d9fef62

use starknet::ContractAddress;

#[starknet::interface]
trait IDTKERC20<TContractState> {
    fn faucet(ref self: TContractState) -> bool;
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn totalSupply(self: @TContractState) -> u256;
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, to: ContractAddress, amount: u256) -> bool;
    fn transferFrom(ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
    fn mint(ref self: TContractState, amount: u256);
    fn burn(ref self: TContractState, amount: u256);
}

#[starknet::interface]
trait IExerciseSolution<TContractState> {
    fn deposit_tokens(ref self: TContractState, amount: u256) -> u256;
    fn tokens_in_custody(self: @TContractState, account: ContractAddress) -> u256;
    fn get_tokens_from_contract(ref self: TContractState) -> u256;
    fn withdraw_all_tokens(ref self: TContractState) -> u256;
    fn deposit_tracker_token(self: @TContractState) -> ContractAddress;
}

#[starknet::contract]
mod ExerciseSolution {

    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_contract_address;

    use super::IDTKERC20Dispatcher;
    use super::IDTKERC20DispatcherTrait;

    #[storage]
    struct Storage {
        _dtk_account: ContractAddress,
        _tracker_token_account: ContractAddress,
        _balances: LegacyMap::<ContractAddress, u256>
    }
    
    #[constructor]
    fn constructor(ref self: ContractState, dtk_account: ContractAddress, tracker_token_account: ContractAddress) {
        self._dtk_account.write(dtk_account);
        self._tracker_token_account.write(tracker_token_account);
    }

    #[external(v0)]
    impl ExerciseSolution of super::IExerciseSolution<ContractState> {
        fn deposit_tokens(ref self: ContractState, amount: u256) -> u256 {
            let account = get_caller_address();
            IDTKERC20Dispatcher{contract_address: self._dtk_account.read()}.transferFrom(account, get_contract_address(), amount);
            
            IDTKERC20Dispatcher{contract_address: self._tracker_token_account.read()}.mint(amount);
            IDTKERC20Dispatcher{contract_address: self._tracker_token_account.read()}.transfer(account, amount);

            self._balances.write(account, self._balances.read(account) + amount);
            amount
        }
        fn tokens_in_custody(self: @ContractState, account: ContractAddress) -> u256 {
            return self._balances.read(account);
        }
        fn get_tokens_from_contract(ref self: ContractState) -> u256 {
            let account = get_caller_address();
            let amount = 100000000000000000000;
            IDTKERC20Dispatcher{contract_address: self._dtk_account.read()}.faucet();
            self._balances.write(account, self._balances.read(account) + amount);
            return amount;
        }

        fn withdraw_all_tokens(ref self: ContractState) -> u256 {
            let account = get_caller_address();
            let account_balance = self._balances.read(account);
            if (account_balance==0_u256){
                return 0_u256;
            }
            IDTKERC20Dispatcher{contract_address: self._dtk_account.read()}.transfer(account, account_balance);
            self._balances.write(account,0_u256);

            IDTKERC20Dispatcher{contract_address: self._tracker_token_account.read()}.transferFrom(account, get_contract_address(), account_balance);
            IDTKERC20Dispatcher{contract_address: self._tracker_token_account.read()}.burn(account_balance);

            return account_balance;
        }

        fn deposit_tracker_token(self: @ContractState) -> ContractAddress {
            self._tracker_token_account.read()
        }
    }
}