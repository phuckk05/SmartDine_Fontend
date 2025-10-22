package com.smartdine.models;

import com.smartdine.models.idclass.ReservationTableId;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@Entity
@Table(name = "reservation_tables")
@IdClass(ReservationTableId.class)
public class ReservationTable {

    @Id
    @Column(name = "reservation_id")
    private Integer reservationId;

    @Id
    @Column(name = "table_id")
    private Integer tableId;

    public ReservationTable() {
    }

    public ReservationTable(Integer reservationId, Integer tableId) {
        this.reservationId = reservationId;
        this.tableId = tableId;
    }

    public Integer getReservationId() {
        return reservationId;
    }

    public void setReservationId(Integer reservationId) {
        this.reservationId = reservationId;
    }

    public Integer getTableId() {
        return tableId;
    }

    public void setTableId(Integer tableId) {
        this.tableId = tableId;
    }
}
