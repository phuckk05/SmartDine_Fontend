package com.smartdine.repository;

<<<<<<< HEAD
import java.util.List;

=======
>>>>>>> origin/branch-management-api-v1.2
import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.Item;

public interface ItemRepository extends JpaRepository<Item, Integer> {
<<<<<<< HEAD
    //Lay items comapanyId & statusId
    public List<Item> getByCompanyId(Integer companyId);
=======
>>>>>>> origin/branch-management-api-v1.2
}
