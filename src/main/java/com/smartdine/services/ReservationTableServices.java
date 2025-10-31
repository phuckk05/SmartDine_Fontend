package com.smartdine.services;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.ReservationTable;
import com.smartdine.models.idclass.ReservationTableId;
import com.smartdine.repository.ReservationTableRepository;

@Service
public class ReservationTableServices {

    @Autowired
    ReservationTableRepository reservationTableRepository;

    // Lưu ReservationTable
    public ReservationTable saveReservationTable(ReservationTable reservationTable) {
        return reservationTableRepository.save(reservationTable);
    }

    // Lưu nhiều ReservationTable
    public List<ReservationTable> saveReservationTables(List<ReservationTable> reservationTables) {
        return reservationTableRepository.saveAll(reservationTables);
    }

    // Lấy tất cả ReservationTable
    public List<ReservationTable> getAllReservationTables() {
        return reservationTableRepository.findAll();
    }

    // Lấy ReservationTable theo id
    public Optional<ReservationTable> getReservationTableById(ReservationTableId id) {
        return reservationTableRepository.findById(id);
    }

    // Lấy danh sách table theo reservationId
    public List<ReservationTable> getReservationTablesByReservationId(Integer reservationId) {
        return reservationTableRepository.findByReservationId(reservationId);
    }

    // Lấy danh sách reservation theo tableId
    public List<ReservationTable> getReservationTablesByTableId(Integer tableId) {
        return reservationTableRepository.findByTableId(tableId);
    }

    // Xóa tất cả ReservationTable theo reservationId
    public void deleteReservationTablesByReservationId(Integer reservationId) {
        reservationTableRepository.deleteByReservationId(reservationId);
    }

    // Xóa tất cả ReservationTable theo tableId
    public void deleteReservationTablesByTableId(Integer tableId) {
        reservationTableRepository.deleteByTableId(tableId);
    }

    // Xóa ReservationTable theo id
    public void deleteReservationTable(ReservationTableId id) {
        reservationTableRepository.deleteById(id);
    }

    // Kiểm tra table có được đặt chưa
    public boolean isTableReserved(Integer tableId) {
        return reservationTableRepository.existsByTableId(tableId);
    }

    // Kiểm tra ReservationTable có tồn tại không
    public boolean existsById(ReservationTableId id) {
        return reservationTableRepository.existsById(id);
    }
}