package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.status.PaymentStatus;
import com.smartdine.repository.PaymentStatusRepository;

@Service
public class PaymentStatusServices {
    @Autowired
    private PaymentStatusRepository paymentStatusRepository;

    public List<PaymentStatus> getAll() {
        return paymentStatusRepository.findAll();
    }

    public PaymentStatus getById(Integer id) {
        return paymentStatusRepository.findById(id).orElse(null);
    }
}
