package com.squareup.connectexamples.ecommerce;

public class WalletTopUpWrapper {
    private final String nonce;
    private final long amount;
    private final String currency;
    private final String name;

    public WalletTopUpWrapper(String nonce, long amount, String currency, String name) {
        this.nonce = nonce;
        this.amount = amount;
        this.currency = currency;
        this.name = name;
    }

    public String getNonce() {
        return nonce;
    }

    public long getAmount() {
        return amount;
    }

    public String getCurrency() {
        return currency;
    }

    public String getName() {
        return name;
    }
}
