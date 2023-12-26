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
actor {
    public type Result = {
        #Ok: Text;
        #Err: Text;
    };

    private stable var whitelist: [Principal] = [];
    private stable var governance_canister_id: ?Principal = null;

    private func is_governance_canister(p: Principal) : Bool {
        switch (governance_canister_id) {
            case (?id) { Principal.equal(id, p) };
            case (_)   { false };
        }
    };

    public shared func set_governance_canister_id(cid: ?Principal): async ?Principal {
        governance_canister_id := cid;
        return governance_canister_id;
    };
    public query func get_governance_canister_id(): async ?Principal {
        return governance_canister_id;
    };
    public shared func add_whitelist(principal: Principal): async [Principal] {
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
        return #Ok("ok");
    };
    public shared func remove_whitelist(principal: Principal): async [Principal] {
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
        return #Ok("ok");
    };
    public query func get_whitelist(): async [Principal] {
        return whitelist;
    };
    /// The validator of transferPosition.
    public shared({caller}) func validate_transfer_position(from : Principal, to : Principal, positionId : Nat): async Result {
        for (it in whitelist.vals()) {
            if (Principal.equal(it, from)) {
                return #Ok("ok");
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
            case (#set_governance_canister_id args)    { Prim.isController(caller) };
            case (_)                                   { true };
        }
    };
};