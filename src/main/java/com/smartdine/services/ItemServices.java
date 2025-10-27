package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Item;
import com.smartdine.repository.ItemRepository;

@Service
public class ItemServices {
    @Autowired
    private ItemRepository itemRepository;

    // Lay item theo company id
    public List<Item> getByCompanyId(Integer companyId) {
        return itemRepository.getByCompanyId(companyId);
    }

    // Lay item theo id
    public Item getById(Integer id) {
        return itemRepository.findById(id).orElse(null);
    }

    // Cap nhat trang thai item
    public Item updateItemStatus(Integer id, Integer statusId) {
        Item item = getById(id);
        if (item != null) {
            item.setStatus(statusId);
            return itemRepository.save(item);
        }
        return null;
    }
}
