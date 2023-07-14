//deployed on 0x008a78670b663dd1b3d7dff109b5c65d42d012cdc1806673360d261fff15aa5f

use starknet::ContractAddress;

#[starknet::interface]
trait IEX01<TContractState> {
    fn claim_points(ref self: TContractState);
}

#[starknet::interface]
trait IEX02<TContractState> {
    fn claim_points(ref self: TContractState, my_value: u128);
    fn my_secret_value(self: @TContractState) -> u128;
}

#[starknet::interface]
trait IEX03<TContractState> {
    fn claim_points(ref self: TContractState);
    fn increment_counter(ref self: TContractState);
    fn decrement_counter(ref self: TContractState);
}

#[starknet::interface]
trait IEX04<TContractState> {
    fn claim_points(ref self: TContractState, my_value: u128);
    fn assign_user_slot(ref self: TContractState);
    fn get_user_slots(self: @TContractState, account: ContractAddress) -> u128;
    fn get_values_mapped(self: @TContractState, slot: u128) -> u128;
}

#[starknet::interface]
trait IEX05<TContractState> {
    fn claim_points(ref self: TContractState, my_value: u128);
    fn assign_user_slot(ref self: TContractState);
    fn copy_secret_value_to_readable_mapping(ref self: TContractState);
    fn get_user_slots(self: @TContractState, account: ContractAddress) -> u128;
    fn get_user_values(self: @TContractState, account: ContractAddress) -> u128;
}

#[starknet::interface]
trait IEX06<TContractState> {
    fn claim_points(ref self: TContractState, my_value: u128);
    fn assign_user_slot(ref self: TContractState);
    fn external_handler_for_internal_function(ref self: TContractState,  a_value: u128);
    fn get_user_slots(self: @TContractState, account: ContractAddress) -> u128;
    fn get_user_values(self: @TContractState, account: ContractAddress) -> u128;
}

#[starknet::interface]
trait IEX07<TContractState> {
    fn claim_points(ref self: TContractState, value_a: u128, value_b: u128);
}

#[starknet::interface]
trait IEX08<TContractState> {
    fn claim_points(ref self: TContractState);
    fn set_user_values(ref self: TContractState, account: ContractAddress, values: Array::<u128>);
}

#[starknet::interface]
trait IEX09<TContractState> {
    fn claim_points(ref self: TContractState, values: Array::<u128>);
}

#[starknet::interface]
trait IEX11<TContractState> {
    fn claim_points(ref self: TContractState, secret_value_i_guess: u128, next_secret_value_i_chose: u128);
    fn secret_value(self: @TContractState) -> u128;
}

#[starknet::interface]
trait IAllForTash<TContractState> {

    fn claim(ref self: TContractState, target: ContractAddress);
    fn set_selfAddress(ref self: TContractState, contract: ContractAddress);

    fn validate_various_exercises(ref self: TContractState);
}

#[starknet::contract]
mod AllForTash {

    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use array::ArrayTrait;

    use super::IEX01Dispatcher;
    use super::IEX01DispatcherTrait;
    use super::IEX02Dispatcher;
    use super::IEX02DispatcherTrait;
    use super::IEX03Dispatcher;
    use super::IEX03DispatcherTrait;
    use super::IEX04Dispatcher;
    use super::IEX04DispatcherTrait;
    use super::IEX05Dispatcher;
    use super::IEX05DispatcherTrait;
    use super::IEX06Dispatcher;
    use super::IEX06DispatcherTrait;
    use super::IEX07Dispatcher;
    use super::IEX07DispatcherTrait;
    use super::IEX08Dispatcher;
    use super::IEX08DispatcherTrait;
    use super::IEX09Dispatcher;
    use super::IEX09DispatcherTrait;
    use super::IEX11Dispatcher;
    use super::IEX11DispatcherTrait;

    #[storage]
    struct Storage {
        selfAddress : ContractAddress,
        contract1: ContractAddress,
        contract2: ContractAddress,
        contract3: ContractAddress,
        contract4: ContractAddress,
        contract5: ContractAddress,
        contract6: ContractAddress,
        contract7: ContractAddress,
        contract8: ContractAddress,
        contract9: ContractAddress,
        contract11: ContractAddress
    }

    #[constructor]
    fn constructor(ref self: ContractState, ex1: ContractAddress, ex2: ContractAddress, ex3: ContractAddress, ex4: ContractAddress, ex5: ContractAddress, ex6: ContractAddress, ex7: ContractAddress, ex8: ContractAddress, ex9: ContractAddress, ex11: ContractAddress) {
        self.contract1.write(ex1);
        self.contract2.write(ex2);
        self.contract3.write(ex3);
        self.contract4.write(ex4);
        self.contract5.write(ex5);
        self.contract6.write(ex6);
        self.contract7.write(ex7);
        self.contract8.write(ex8);
        self.contract9.write(ex9);
        self.contract11.write(ex11);
    }

    #[external(v0)]
    impl TestCall of super::IAllForTash<ContractState> {

        fn claim(ref self: ContractState, target: ContractAddress) {
            IEX01Dispatcher{contract_address: target}.claim_points();
        }

        fn set_selfAddress(ref self: ContractState, contract: ContractAddress) {
            self.selfAddress.write(contract);
        }

        fn validate_various_exercises(ref self: ContractState) {
            //EX 01
            IEX01Dispatcher{contract_address: self.contract1.read()}.claim_points();

            //EX 02
            let secretValue: u128 = IEX02Dispatcher{contract_address: self.contract2.read()}.my_secret_value();
            IEX02Dispatcher{contract_address: self.contract2.read()}.claim_points(secretValue);

            //EX 03
            IEX03Dispatcher{contract_address: self.contract3.read()}.increment_counter();
            IEX03Dispatcher{contract_address: self.contract3.read()}.decrement_counter();
            IEX03Dispatcher{contract_address: self.contract3.read()}.increment_counter();
            IEX03Dispatcher{contract_address: self.contract3.read()}.claim_points();

            //EX 04
            IEX04Dispatcher{contract_address: self.contract4.read()}.assign_user_slot();
            let slot: u128 = IEX04Dispatcher{contract_address: self.contract4.read()}.get_user_slots(self.selfAddress.read());
            let valueMapped: u128 = IEX04Dispatcher{contract_address: self.contract4.read()}.get_values_mapped(slot);
            IEX04Dispatcher{contract_address: self.contract4.read()}.claim_points(valueMapped - 32_u128);

            //EX 05
            IEX05Dispatcher{contract_address: self.contract5.read()}.assign_user_slot();
            let slot: u128 = IEX05Dispatcher{contract_address: self.contract5.read()}.get_user_slots(self.selfAddress.read());
            IEX05Dispatcher{contract_address: self.contract5.read()}.copy_secret_value_to_readable_mapping();
            let userValue: u128 = IEX05Dispatcher{contract_address: self.contract5.read()}.get_user_values(self.selfAddress.read()) + 23_u128;
            IEX05Dispatcher{contract_address: self.contract5.read()}.claim_points(userValue - 32_u128);

            //EX 06
            IEX06Dispatcher{contract_address: self.contract6.read()}.assign_user_slot();
            IEX06Dispatcher{contract_address: self.contract6.read()}.external_handler_for_internal_function(5_u128);
            let userValue: u128 = IEX06Dispatcher{contract_address: self.contract6.read()}.get_user_values(self.selfAddress.read());
            IEX06Dispatcher{contract_address: self.contract6.read()}.claim_points(userValue);

            //EX 07
            IEX07Dispatcher{contract_address: self.contract7.read()}.claim_points(50_u128, 0_u128);

            //EX 08
            let mut values = ArrayTrait::<u128>::new();
            values.append(10_u128);
            values.append(10_u128);
            values.append(10_u128);
            values.append(10_u128);
            values.append(10_u128);
            values.append(10_u128);
            values.append(10_u128);
            values.append(10_u128);
            values.append(10_u128);
            values.append(10_u128);
            values.append(10_u128);
            IEX08Dispatcher{contract_address: self.contract8.read()}.set_user_values(self.selfAddress.read(), values);
            IEX08Dispatcher{contract_address: self.contract8.read()}.claim_points();

            //EX 09
            let mut array = ArrayTrait::<u128>::new();
            array.append(20_u128);
            array.append(20_u128);
            array.append(20_u128);
            array.append(20_u128);
            IEX09Dispatcher{contract_address: self.contract9.read()}.claim_points(array);

            //EX 11
            let secretIGuess: u128 = IEX11Dispatcher{contract_address: self.contract11.read()}.secret_value() -42069_u128;
            IEX11Dispatcher{contract_address: self.contract11.read()}.claim_points(secretIGuess,123546842_u128);
        }
    }
}