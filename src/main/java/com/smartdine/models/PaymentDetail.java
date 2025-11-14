package com.smartdine.models;

import java.math.BigDecimal;

import com.smartdine.models.idclass.PaymentDetailId;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@Entity
@Table(name = "payment_details")
@IdClass(PaymentDetailId.class)
public class PaymentDetail {

    @Id
    @Column(name = "payment_id")
    private Integer paymentId;

    @Id
    @Column(name = "company_payment_method_id")
    private Integer companyPaymentMethodId;

    private BigDecimal amount;

    public PaymentDetail() {
    }

    public PaymentDetail(Integer paymentId, Integer companyPaymentMethodId, BigDecimal amount) {
        this.paymentId = paymentId;
        this.companyPaymentMethodId = companyPaymentMethodId;
        this.amount = amount;
    }

    public Integer getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(Integer paymentId) {
        this.paymentId = paymentId;
    }

    public Integer getCompanyPaymentMethodId() {
        return companyPaymentMethodId;
    }

    public void setCompanyPaymentMethodId(Integer companyPaymentMethodId) {
        this.companyPaymentMethodId = companyPaymentMethodId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
}
