package com.smartdine.models;

import com.smartdine.models.idclass.MenuItemId;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@Entity
@Table(name = "menu_items")
@IdClass(MenuItemId.class)
public class MenuItem {

    @Id
    @Column(name = "menu_id")
    private Integer menuId;

    @Id
    @Column(name = "item_id")
    private Integer itemId;

    @Column(name = "category_id")
    private Integer categoryId;

    public MenuItem() {
    }

    public MenuItem(Integer menuId, Integer itemId, Integer categoryId) {
        this.menuId = menuId;
        this.itemId = itemId;
        this.categoryId = categoryId;
    }

    public Integer getMenuId() {
        return menuId;
    }

    public void setMenuId(Integer menuId) {
        this.menuId = menuId;
    }

    public Integer getItemId() {
        return itemId;
    }

    public void setItemId(Integer itemId) {
        this.itemId = itemId;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }
}
