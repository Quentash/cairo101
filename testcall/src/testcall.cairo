// has ben deployed on 0x0678d54816b6fc8772895c363ccc95b2899bf7c6a08b7859f0613ae9a8654a9b

use starknet::ContractAddress;

#[starknet::interface]
trait IClaimable<TContractState> {
    fn claim_points(ref self: TContractState);
}

#[starknet::interface]
trait ITestCall<TContractState> {

    fn execute(ref self: TContractState, target: ContractAddress);

}

#[starknet::contract]
mod TestCall {

    use starknet::ContractAddress;
    use starknet::get_caller_address;

    use super::IClaimableDispatcher;
    use super::IClaimableDispatcherTrait;

    #[storage]
    struct Storage {
        
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        NameChanged: NameChanged
    }

    #[derive(Drop, starknet::Event)]
    struct NameChanged {
        newName: ContractAddress
    }

    #[external(v0)]
    impl TestCall of super::ITestCall<ContractState> {

        fn execute(ref self: ContractState, target: ContractAddress) {
            IClaimableDispatcher{contract_address: target}.claim_points();
        }
    }
}