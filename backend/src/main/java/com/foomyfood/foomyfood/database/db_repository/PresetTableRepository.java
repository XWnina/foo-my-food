package com.foomyfood.foomyfood.database.db_repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.PresetTable;

@Repository
public interface PresetTableRepository extends JpaRepository<PresetTable, Long> {

    boolean existsByName(String name);

    Optional<PresetTable> findByName(String foodName);

    // 新增模糊搜索功能，支持不区分大小写的查询
    List<PresetTable> findByNameContainingIgnoreCase(String query);
}
