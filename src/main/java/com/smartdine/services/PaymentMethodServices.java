package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.PaymentMethod;
import com.smartdine.repository.PaymentMethodRepository;

@Service
public class PaymentMethodServices {
    @Autowired
    private PaymentMethodRepository paymentMethodRepository;

    public List<PaymentMethod> getAll() {
        return paymentMethodRepository.findAll();
    }
}
