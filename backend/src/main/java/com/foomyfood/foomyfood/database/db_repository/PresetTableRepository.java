package com.foomyfood.foomyfood.database.db_repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.PresetTable;

@Repository
public interface PresetTableRepository extends JpaRepository<PresetTable, Long> {
}
