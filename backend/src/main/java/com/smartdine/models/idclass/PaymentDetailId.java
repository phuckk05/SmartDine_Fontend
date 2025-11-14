package com.smartdine.models.idclass;

import java.io.Serializable;
import java.util.Objects;

public class PaymentDetailId implements Serializable {
    private Integer paymentId;
    private Integer companyPaymentMethodId;

    public PaymentDetailId() {
    }

    public PaymentDetailId(Integer paymentId, Integer companyPaymentMethodId) {
        this.paymentId = paymentId;
        this.companyPaymentMethodId = companyPaymentMethodId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof PaymentDetailId)) {
            return false;
        }
        PaymentDetailId that = (PaymentDetailId) o;
        return Objects.equals(paymentId, that.paymentId)
                && Objects.equals(companyPaymentMethodId, that.companyPaymentMethodId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(paymentId, companyPaymentMethodId);
    }
}
