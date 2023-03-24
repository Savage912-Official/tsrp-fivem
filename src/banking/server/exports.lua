Exports = {}

function Exports.deposit(player_id, amount, callback)
    if amount < 1 then
        callback(false, "Amount must be greater than 0.")
        return
    end

    BankAccount.for_player(player_id, function(account)
        account:adjust(amount)
        callback(account.balance)
    end)
end
exports("Deposit", Exports.deposit)

function Exports.withdraw(player_id, amount, callback)
    if amount < 1 then
        callback(false, "Amount must be greater than 0.")
        return
    end

    BankAccount.for_player(player_id, function(account)
        account:adjust(amount * -1)
        callback(account.balance)
    end)
end
exports("Withdraw", Exports.withdraw)
