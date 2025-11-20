package com.smartdine.services;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Item;
import com.smartdine.repository.ItemRepository;

@Service
public class ItemServices {
    @Autowired
    private ItemRepository itemRepository;

    // Lấy danh sách item theo công ty và (tùy chọn) theo category
    public List<Item> getItems(Integer companyId, Integer categoryId) {
        if (companyId == null) {
            throw new IllegalArgumentException("companyId is required");
        }
        if (categoryId != null) {
            return itemRepository.findByCompanyIdAndCategoryId(companyId, categoryId);
        }
        return itemRepository.findByCompanyId(companyId);
    }

    // Lấy item theo company id (giữ lại cho tương thích cũ)
    public List<Item> getByCompanyId(Integer companyId) {
        return getItems(companyId, null);
    }

    // Lay item theo id
    public Item getById(Integer id) {
        return itemRepository.findById(id).orElse(null);
    }

    // Tạo item mới
    public Item createItem(Item item) {
        LocalDateTime now = LocalDateTime.now();
        if (item.getCreatedAt() == null) {
            item.setCreatedAt(now);
        }
        item.setUpdatedAt(now);
        return itemRepository.save(item);
    }

    // Cập nhật toàn bộ thông tin item
    public Item updateItem(Integer id, Item payload) {
        return itemRepository.findById(id).map(existing -> {
            if (payload.getName() != null) {
                existing.setName(payload.getName());
            }
            if (payload.getPrice() != null) {
                existing.setPrice(payload.getPrice());
            }
            if (payload.getCompanyId() != null) {
                existing.setCompanyId(payload.getCompanyId());
            }
            if (payload.getStatusId() != null) {
                existing.setStatusId(payload.getStatusId());
            }
            existing.setUpdatedAt(LocalDateTime.now());
            return itemRepository.save(existing);
        }).orElse(null);
    }

    // Cap nhat trang thai item
    public Item updateItemStatus(Integer id, Integer statusId) {
        Item item = getById(id);
        if (item != null) {
            item.setStatusId(statusId);
            return itemRepository.save(item);
        }
        return null;
    }

    // Xóa item
    public boolean deleteItem(Integer id) {
        Item item = itemRepository.findById(id).orElse(null);
        if (item == null) {
            return false;
        }

        Integer statusId = item.getStatusId();
        if (statusId == null || statusId.intValue() != 1) {
            throw new IllegalStateException("Chỉ được phép xóa món ở trạng thái chờ duyệt (statusId = 1).");
        }

        itemRepository.deleteById(id);
        return true;
    }
}
