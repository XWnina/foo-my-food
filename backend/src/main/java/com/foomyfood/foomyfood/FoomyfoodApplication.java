package com.foomyfood.foomyfood;

import javax.annotation.PreDestroy;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;


@SpringBootApplication(scanBasePackages = "com.foomyfood.foomyfood")
@EntityScan(basePackages = "com.foomyfood.foomyfood")
@EnableJpaRepositories(basePackages = "com.foomyfood.foomyfood.database.db_repository")
public class FoomyfoodApplication {



	public static void main(String[] args) {
		SpringApplication.run(FoomyfoodApplication.class, args);
		System.out.println("Backend running ...");
	}
	@PreDestroy
	public void onShutdown() {
		System.out.println("Backend stopped ...");
	}

}
