import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Prim "mo:⛔";
import Bool "mo:base/Bool";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";

/// This validator implements the verification that the receiving principal must be in the whitelist. You can add this canister to SNS Dao.
/// Only controller and governance canister can call add_whitelist and remove_whitelist method to add or remove the principal from the whitelist.
/// Only controller can set governance canister id using set_governance_canister_id method.
actor class TransferPositionValidator(governance_id: ?Principal) {
    public type Result = {
        #Ok: Text;
        #Err: Text;
    };

    private stable var whitelist: [Principal] = [];

    private func is_governance_canister(p: Principal) : Bool {
        switch (governance_id) {
            case (?id) { Principal.equal(id, p) };
            case (_)   { false };
        }
    };

    public query func get_governance_canister_id(): async ?Principal {
        return governance_id;
    };
    public shared({caller}) func add_whitelist(principal: Principal): async [Principal] {
        assert(Prim.isController(caller) or is_governance_canister(caller));
        var buffer: Buffer.Buffer<Principal> = Buffer.Buffer<Principal>(whitelist.size());
        for (it in whitelist.vals()) {
            if (not Principal.equal(principal, it)) {
                buffer.add(it);
            }
            
        };
        buffer.add(principal);
        whitelist := Buffer.toArray<Principal>(buffer);
        return whitelist;
    };
    public shared func validate_add_whitelist(principal: Principal): async Result {
        return #Ok(Principal.toText(principal));
    };
    public shared({caller}) func remove_whitelist(principal: Principal): async [Principal] {
        assert(Prim.isController(caller) or is_governance_canister(caller));
        var buffer: Buffer.Buffer<Principal> = Buffer.Buffer<Principal>(whitelist.size());
        for (it in whitelist.vals()) {
            if (not Principal.equal(principal, it)) {
                buffer.add(it);
            }
        };
        whitelist := Buffer.toArray<Principal>(buffer);
        return whitelist;
    };
    public shared func validate_remove_whitelist(principal: Principal): async Result {
        return #Ok(Principal.toText(principal));
    };
    public query func get_whitelist(): async [Principal] {
        return whitelist;
    };
    /// The validator of transferPosition.
    public shared({caller}) func validate_transfer_position(from : Principal, to : Principal, positionId : Nat): async Result {
        for (it in whitelist.vals()) {
            if (Principal.equal(it, to)) {
                return #Ok(Principal.toText(from) # ", " # Principal.toText(to) # ", " # Nat.toText(positionId));
            }
        };
        return #Err("the recipient is not on the whitelist.");
    };
    system func inspect({
        arg : Blob;
        caller : Principal;
        msg : {
            #add_whitelist: () -> Principal;
            #validate_add_whitelist: () -> Principal;
            #remove_whitelist: () -> Principal;
            #validate_remove_whitelist: () -> Principal;
            #set_governance_canister_id: () -> ?Principal;
            #get_whitelist: () -> ();
            #get_governance_canister_id: () -> ();
            #validate_transfer_position: () -> (Principal, Principal, Nat);
        };
    }) : Bool {
        switch (msg) {
            case (#add_whitelist args)                 { Prim.isController(caller) or is_governance_canister(caller) };
            case (#remove_whitelist args)              { Prim.isController(caller) or is_governance_canister(caller) };
            case (_)                                   { true };
        }
    };
};