package com.smartdine.repository;

import java.util.List;
import java.util.Optional;

import com.smartdine.response.GetListCompanyAndOwnerResponse;
import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.Company;
import org.springframework.data.jpa.repository.Query;

public interface CompanyRepository extends JpaRepository<Company, Integer> {
    Optional<Company> findByCompanyCode(String companyCode);

    List<Company> findByStatusId(Integer statusId);

    @Query("""
    SELECT new com.smartdine.response.GetListCompanyAndOwnerResponse(
        c.name, 
        u.id, 
        u.fullName, 
        u.phone,
        (SELECT COUNT(ub.branchId) FROM UserBranch ub WHERE ub.userId = u.id)
    )
    FROM Company c
    JOIN User u ON u.companyId = c.id
    WHERE c.statusId = 1 AND u.role = 5
""")
    List<GetListCompanyAndOwnerResponse> getListCompanyAndOwner();


}
