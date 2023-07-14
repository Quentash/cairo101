// has been deployed on 0x0439225530124064cbbc706f95a118d445a78bb55dc57af252fb22841ce1013e

use starknet::ContractAddress;

#[starknet::interface]
trait ISayMyName<TContractState> {

    fn say_my_name(ref self: TContractState);

    fn your_name(self: @TContractState) -> ContractAddress;
}

#[starknet::contract]
mod SayMyName {

    use starknet::ContractAddress;
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        the_name: ContractAddress
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
    impl SayMyName of super::ISayMyName<ContractState> {
        fn say_my_name(ref self: ContractState){
            let callerName: ContractAddress = get_caller_address();
            let currentName = self.the_name.read();

            assert(currentName != callerName, 'ALREADY_YOUR_NAME');

            self.the_name.write(callerName);
            self.emit(NameChanged {newName: callerName});
        }

        fn your_name(self: @ContractState) -> ContractAddress {
            return self.the_name.read();
        }
    }
}