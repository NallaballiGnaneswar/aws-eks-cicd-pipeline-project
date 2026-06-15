package com.devops.demo.service;

import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class AppService {

    public Map<String, String> getAppInfo() {
        Map<String, String> info = new HashMap<>();
        info.put("application", "AWS EKS CI/CD Pipeline Demo");
        info.put("developer", "Gnaneswar Nallaballi");
        info.put("technology", "Spring Boot + Docker + Kubernetes");
        info.put("cloud", "AWS (EKS, ECR, S3)");
        info.put("cicd", "Jenkins Pipeline");
        info.put("codeQuality", "SonarQube");
        return info;
    }
}
