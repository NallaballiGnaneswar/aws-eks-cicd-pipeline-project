package com.devops.demo;

import com.devops.demo.controller.HealthController;
import com.devops.demo.service.AppService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class DemoApplicationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private HealthController healthController;

    @Autowired
    private AppService appService;

    @Test
    void contextLoads() {
        assertThat(healthController).isNotNull();
    }

    @Test
    void healthEndpointReturnsOk() throws Exception {
        mockMvc.perform(get("/api/health"))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.status").value("UP"))
               .andExpect(jsonPath("$.service").value("aws-eks-cicd-pipeline"));
    }

    @Test
    void infoEndpointReturnsOk() throws Exception {
        mockMvc.perform(get("/api/info"))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.application").exists());
    }

    @Test
    void homeEndpointReturnsWelcome() throws Exception {
        mockMvc.perform(get("/api/"))
               .andExpect(status().isOk())
               .andExpect(content().string("Welcome to AWS EKS CI/CD Pipeline Demo Application!"));
    }

    @Test
    void appServiceReturnsInfo() {
        var info = appService.getAppInfo();
        assertThat(info).containsKey("application");
        assertThat(info).containsKey("developer");
        assertThat(info.get("cicd")).isEqualTo("Jenkins Pipeline");
    }
}
