package com.smartdine.models.idclass;

import java.io.Serializable;
import java.util.Objects;

public class MenuItemId implements Serializable {
    private Integer menuId;
    private Integer itemId;

    public MenuItemId() {
    }

    public MenuItemId(Integer menuId, Integer itemId) {
        this.menuId = menuId;
        this.itemId = itemId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof MenuItemId)) {
            return false;
        }
        MenuItemId that = (MenuItemId) o;
        return Objects.equals(menuId, that.menuId) && Objects.equals(itemId, that.itemId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(menuId, itemId);
    }
}
