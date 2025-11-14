package com.smartdine.models.idclass;

import java.io.Serializable;
import java.util.Objects;

public class ReservationTableId implements Serializable {
    private Integer reservationId;
    private Integer tableId;

    public ReservationTableId() {
    }

    public ReservationTableId(Integer reservationId, Integer tableId) {
        this.reservationId = reservationId;
        this.tableId = tableId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof ReservationTableId)) {
            return false;
        }
        ReservationTableId that = (ReservationTableId) o;
        return Objects.equals(reservationId, that.reservationId) && Objects.equals(tableId, that.tableId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(reservationId, tableId);
    }
}
