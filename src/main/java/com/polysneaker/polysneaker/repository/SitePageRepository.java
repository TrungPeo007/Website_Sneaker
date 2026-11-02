package com.polysneaker.polysneaker.repository;

import com.polysneaker.polysneaker.entity.SitePage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SitePageRepository extends JpaRepository<SitePage, Integer> {

    List<SitePage> findAllByOrderBySortOrderAscIdAsc();

    List<SitePage> findByActiveTrueOrderBySortOrderAscIdAsc();

    Optional<SitePage> findBySlugAndActiveTrue(String slug);

    boolean existsBySlug(String slug);

    boolean existsBySlugAndIdNot(String slug, Integer id);
}