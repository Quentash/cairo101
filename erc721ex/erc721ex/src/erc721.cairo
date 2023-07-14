// ex 01 solution on ; 0x0717a58d4c561dddaff3a8f4893deb3097c2b30fa6011bde9205cda55f507489
// ex 02 solution on ; 0x06ee25c1adc7f14e0ec3a6d36901c136c540d51e029479e58d9ead3e853f6cf5
// ex 03 solution on ; 0x0142cac7b12d83fd0432f2cd333894b71fb5b7512286940a4f0231bce0f8fe47  safe_mint() kind of implemented but not working atm, not necessary to finish the exercices tho

use starknet::ContractAddress;

#[starknet::interface]
trait ISRC5<TContractState> {
    fn supports_interface(self: @TContractState, interface_id: felt252) -> bool;
}

#[starknet::interface]
trait IERC721Receiver<TContractState> {
    fn on_erc721_received(self: @TContractState, operator: ContractAddress, from: ContractAddress, token_id: u256, data: Span<felt252>) -> felt252;
}

#[starknet::interface]
trait IExerciceSolution<TContractState> {
    fn get_animal_characteristics(self: @TContractState, token_id: u256) -> (felt252, felt252, felt252);
    fn declare_animal(ref self: TContractState, sex: felt252, legs: felt252, wings: felt252) -> u256;
}

#[starknet::interface]
trait IERC721<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn transfer_from(ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn safe_transfer_from(ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>);
    fn approve(ref self: TContractState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn get_approved(self: @TContractState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(self: @TContractState, owner: ContractAddress, operator: ContractAddress) -> bool;
    fn token_uri(self: @TContractState, token_id: u256) -> felt252;
    fn safe_mint(ref self: TContractState, to: ContractAddress, legs: felt252, sex: felt252, wings:felt252, data: Span<felt252>);

    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;
    fn ownerOf(self: @TContractState, token_id: u256) -> ContractAddress;
    fn transferFrom(ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn safeTransferFrom(ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>);
    fn setApprovalForAll(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn getApproved(self: @TContractState, token_id: u256) -> ContractAddress;
    fn isApprovedForAll(self: @TContractState, owner: ContractAddress, operator: ContractAddress) -> bool;
    fn tokenUri(self: @TContractState, token_id: u256) -> felt252;
    fn safeMint(ref self: TContractState, to: ContractAddress, legs: felt252, sex: felt252, wings:felt252, data: Span<felt252>);

    fn mint(ref self: TContractState, to: ContractAddress, legs: felt252, sex: felt252, wings:felt252);
}

#[starknet::contract]
mod ERC721 {
    const ISRC5_ID: felt252 = 0x3f918d17e5ee77373b56385708f855659a07f75997f365cf87748628532a055;
    const IERC721_REICEVER_ID: felt252 = 0x3a0dff5f70d80458ad14ae37bb182a728e3c8cdda0402a5daa86620bdf910bc;
    const IERC721_METADATA_ID: felt252 = 0x6069a70848f907fa57668ba1875164eb4dcee693952468581406d131081bbd;
    const IERC721_ID: felt252 = 0x33eb2f84c309543403fd69f0d0f363781ef06ef6faeb0131ff16ea3175bd943;
    

    use starknet::ContractAddress;
    use zeroable::Zeroable;
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use super::IERC721ReceiverDispatcher;
    use super::IERC721ReceiverDispatcherTrait;
    use super::ISRC5Dispatcher;
    use super::ISRC5DispatcherTrait;

    #[storage]
    struct Storage {
        _supported_interfaces: LegacyMap::<felt252, bool>,
        _name: felt252,
        _symbol: felt252,
        _owners: LegacyMap<u256, ContractAddress>,
        _balances: LegacyMap<ContractAddress, u256>,
        _token_approvals: LegacyMap<u256, ContractAddress>,
        _operator_approvals: LegacyMap<(ContractAddress, ContractAddress), bool>,
        _token_uri: LegacyMap<u256, felt252>,
        _token_characteristics: LegacyMap<u256, Characteristics>,
        _contract_owner: ContractAddress,
        _current_id: u256
    }

    #[derive(Copy,Drop,Serde, storage_access::StorageAccess)]
    struct Characteristics {
        _legs: felt252,
        _sex: felt252,
        _wings: felt252,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        ApprovalForAll: ApprovalForAll
    }
    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        token_id: u256
    }
    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key]
        owner: ContractAddress,
        #[key]
        approved: ContractAddress,
        token_id: u256
    }
    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        #[key]
        owner: ContractAddress,
        #[key]
        operator: ContractAddress,
        approved: bool
    }

    #[constructor]
    fn constructor(ref self: ContractState, name: felt252, symbol: felt252, owner:ContractAddress) {
        self._initialize(name, symbol);
        self._current_id.write(0_256);
        self._contract_owner.write(owner);
    }

    #[external(v0)]
    impl ExerciceSolution of super::IExerciceSolution<ContractState> {
        fn get_animal_characteristics(self: @ContractState, token_id: u256) -> (felt252, felt252, felt252) {
            assert(InternalFunctions::_exists(self,token_id), 'INVALID_TOKEN_ID');
            (self._token_characteristics.read(token_id)._sex, self._token_characteristics.read(token_id)._legs, self._token_characteristics.read(token_id)._wings)
        }
        fn declare_animal(ref self: ContractState, sex: felt252, legs: felt252, wings: felt252) -> u256 {
            InternalFunctions::_mint(ref self, get_caller_address(), legs, sex, wings)
        }
    }

    #[external(v0)]
    impl ERC721 of super::IERC721<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self._name.read()
        }
        fn symbol(self: @ContractState) -> felt252 {
            self._symbol.read()
        }
        fn token_uri(self: @ContractState, token_id: u256) -> felt252 {
            assert(InternalFunctions::_exists(self,token_id), 'INVALID_TOKEN_ID');
            return self._token_uri.read(token_id);
        }
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            assert(!account.is_zero(), 'INVALID_ACCOUNT');
            return self._balances.read(account);
        }
        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            return InternalFunctions::_owner_of(self, token_id);
        }
        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            assert(InternalFunctions::_exists(self,token_id), 'INVALID_TOKEN_ID');
            return self._token_approvals.read(token_id);
        }
        fn is_approved_for_all(self: @ContractState, owner: ContractAddress, operator: ContractAddress) -> bool {
            return self._operator_approvals.read((owner, operator));
        }
        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let owner = InternalFunctions::_owner_of(@self, token_id);

            let caller = get_caller_address();

            assert((owner == caller) | ERC721::is_approved_for_all(@self, owner, caller), 'ERC721: unauthorized caller');

            InternalFunctions::_approve(ref self, to, token_id);
        }
        fn set_approval_for_all(ref self: ContractState, operator: ContractAddress, approved: bool) {
            InternalFunctions::_set_approval_for_all(ref self,get_caller_address(), operator, approved);
        }
        fn transfer_from(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256) {
            assert(InternalFunctions::_is_approved_or_owner(@self, get_caller_address(), token_id), 'unauthorized caller');

            InternalFunctions::_transfer(ref self, from, to, token_id);
        }
        fn safe_transfer_from(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>) {
            assert(InternalFunctions::_is_approved_or_owner(@self, get_caller_address(), token_id), 'unauthorized caller');

            InternalFunctions::_safe_transfer(ref self, from, to, token_id, data);
        }
        fn safe_mint(ref self: ContractState, to: ContractAddress, legs: felt252, sex: felt252, wings:felt252, data: Span<felt252>) {
            assert(get_caller_address() == self._contract_owner.read(), 'unauthorized');
            InternalFunctions::_safe_mint(ref self, to, legs, sex, wings, data);
        }

        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            return ERC721::balance_of(self, account);
        }
        fn ownerOf(self: @ContractState, token_id: u256) -> ContractAddress {
            return ERC721::owner_of(self, token_id);
        }
        fn transferFrom(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256) {
            ERC721::transfer_from(ref self, from, to, token_id);
        }
        fn safeTransferFrom(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>) {
            ERC721::safe_transfer_from(ref self, from, to, token_id, data);
        }
        fn setApprovalForAll(ref self: ContractState, operator: ContractAddress, approved: bool) {
            ERC721::set_approval_for_all(ref self, operator, approved);
        }
        fn getApproved(self: @ContractState, token_id: u256) -> ContractAddress {
            ERC721::get_approved(self, token_id)
        }
        fn isApprovedForAll(self: @ContractState, owner: ContractAddress, operator: ContractAddress) -> bool {
            ERC721::is_approved_for_all(self, owner, operator)
        }
        fn tokenUri(self: @ContractState, token_id: u256) -> felt252 {
            ERC721::token_uri(self, token_id)
        }
        fn safeMint(ref self: ContractState, to: ContractAddress, legs: felt252, sex: felt252, wings:felt252, data: Span<felt252>) {
            assert(get_caller_address() == self._contract_owner.read(), 'unauthorized');
            ERC721::safe_mint(ref self, to, legs, sex, wings, data);
        }

        fn mint(ref self: ContractState, to: ContractAddress, legs: felt252, sex: felt252, wings:felt252) {
            assert(get_caller_address() == self._contract_owner.read(), 'unauthorized');
            InternalFunctions::_mint(ref self, to, legs, sex, wings);
        }
    }

    #[external(v0)]
    impl SRC5Impl of super::ISRC5<ContractState> {
        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            if (interface_id == ISRC5_ID) {
                return true;
            }
            return(self._supported_interfaces.read(interface_id));
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn _initialize(ref self: ContractState, name: felt252, symbol: felt252) {
            self._name.write(name);
            self._symbol.write(symbol);
            InternalFunctions::_register_interface(ref self, IERC721_ID);
            InternalFunctions::_register_interface(ref self, IERC721_METADATA_ID);
        }
        fn _register_interface(ref self: ContractState, interface_id: felt252) {
            self._supported_interfaces.write(interface_id, true);
        }
        fn _deregister_interface(ref self: ContractState, interface_id: felt252) {
            self._supported_interfaces.write(interface_id, false);
        }
        fn _exists(self: @ContractState, token_id: u256) -> bool {
            return !self._owners.read(token_id).is_zero();
        }
        fn _owner_of(self: @ContractState, token_id: u256)-> ContractAddress {
            let owner = self._owners.read(token_id);
            match owner.is_zero() {
                bool::False(()) => owner,
                bool::True(()) => panic_with_felt252('blob')
            }
        }
        fn _approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let owner = InternalFunctions::_owner_of(@self, token_id);
            assert(owner != to, 'ERC721: approval to owner');

            self._token_approvals.write(token_id, to);
            self.emit(Event::Approval(Approval { owner, approved: to, token_id}));
        }
        fn _set_approval_for_all(ref self: ContractState, owner: ContractAddress, operator: ContractAddress, approved: bool) {
            assert(owner != operator, 'self approval');
            self._operator_approvals.write((owner, operator), approved);
            self.emit(Event::ApprovalForAll(ApprovalForAll { owner, operator, approved}));
        }
        fn _is_approved_or_owner(self: @ContractState, spender: ContractAddress, token_id: u256) -> bool {
            let owner = InternalFunctions::_owner_of(self, token_id);

            (owner == spender) | ERC721::is_approved_for_all(self, owner, spender) | (spender == ERC721::get_approved(self, token_id))
        }
        fn _transfer(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256) {
            assert(!to.is_zero(), 'invalid receiver');
            let owner = InternalFunctions::_owner_of(@self, token_id);
            assert(from == owner, 'wrong sender');

            self._token_approvals.write(token_id, Zeroable::zero());

            self._balances.write(from, self._balances.read(from) - 1 );
            self._balances.write(to, self._balances.read(from) + 1 );

            self._owners.write(token_id, to);

            self.emit(Event::Transfer(Transfer { from, to, token_id}));
        }
        fn _safe_transfer(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>) {
            InternalFunctions::_transfer(ref self, from, to, token_id);
            assert(InternalFunctions::_check_on_erc721_received(@self, from, to, token_id, data), 'safe transfer failed');
        }
        fn _check_on_erc721_received(self: @ContractState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>) -> bool {
            if (ISRC5Dispatcher{contract_address: to}.supports_interface(IERC721_REICEVER_ID)) {
                return IERC721ReceiverDispatcher{contract_address: to}.on_erc721_received(get_caller_address(), from, token_id, data) == IERC721_REICEVER_ID;
            } else {
                return ISRC5Dispatcher{contract_address: to}.supports_interface(ISRC5_ID);
            }
        }
        fn _mint(ref self: ContractState, to: ContractAddress, legs: felt252, sex: felt252, wings:felt252) -> u256 {
            assert(!to.is_zero(), 'invalid receiver');

            let token_id = self._current_id.read();
            self._current_id.write(self._current_id.read() + 1);

            self._balances.write(to, self._balances.read(to) + 1);

            self._owners.write(token_id, to);

            //alloc stats
            self._token_characteristics.write(token_id,Characteristics {_legs: legs,_sex: sex,_wings:wings});

            self.emit(Event::Transfer(Transfer { from: Zeroable::zero(), to, token_id}));

            token_id
        }
        fn _safe_mint(ref self: ContractState, to: ContractAddress, legs: felt252, sex: felt252, wings:felt252, data: Span<felt252>) -> u256 {
            let token_id = InternalFunctions::_mint(ref self, to, legs, sex, wings);
            assert(InternalFunctions::_check_on_erc721_received(@self, Zeroable::zero(), to, token_id, data), 'safe mint failed');

            token_id
        }
    }
}