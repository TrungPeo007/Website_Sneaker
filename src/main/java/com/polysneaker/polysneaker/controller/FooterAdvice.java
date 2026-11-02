package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.entity.SitePage;
import com.polysneaker.polysneaker.service.SitePageService;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.List;
@ControllerAdvice
public class FooterAdvice {

    private final SitePageService pages;

    public FooterAdvice(SitePageService pages) {
        this.pages = pages;
    }

    @ModelAttribute("footerServicePages")
    public List<SitePage> footerServicePages() {
        return pages.footerPages(SitePageService.GROUP_SERVICE);
    }

    @ModelAttribute("footerPolicyPages")
    public List<SitePage> footerPolicyPages() {
        return pages.footerPages(SitePageService.GROUP_POLICY);
    }
}