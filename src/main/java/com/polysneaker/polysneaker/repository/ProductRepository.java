package com.polysneaker.polysneaker.repository;

import com.polysneaker.polysneaker.entity.Product;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, Integer> {

    // Trang admin: tất cả sản phẩm (kèm danh mục + size để tính tồn kho)
    @Query("select distinct p from Product p join fetch p.category left join fetch p.details order by p.id desc")
    List<Product> findAllForAdmin();

    // Trang chủ: sản phẩm đang bán, mới nhất trước
    @Query("select p from Product p join fetch p.category c " +
           "where p.active = true and c.active = true order by p.createdAt desc, p.id desc")
    List<Product> findForHome(Pageable pageable);

    // Form sửa: 1 sản phẩm kèm danh mục + size
    @Query("select p from Product p join fetch p.category left join fetch p.details where p.id = :id")
    Optional<Product> findDetailById(@Param("id") Integer id);
}