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

    //Lay item theo company id
    public List<Item> getByCompanyId(Integer companyId){
        return itemRepository.getByCompanyId(companyId);
    }
}
