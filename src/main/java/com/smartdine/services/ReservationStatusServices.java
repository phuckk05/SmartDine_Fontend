package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.ReservationStatus;
import com.smartdine.repository.ReservationStatusRepository;

@Service
public class ReservationStatusServices {
    @Autowired
    private ReservationStatusRepository reservationStatusRepository;

    public List<ReservationStatus> getAll() {
        return reservationStatusRepository.findAll();
    }

    public ReservationStatus getById(Integer id) {
        return reservationStatusRepository.findById(id).orElse(null);
    }
}
