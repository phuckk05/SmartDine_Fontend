package com.smartdine.backend;

import com.smartdine.backend.model.User;
import com.smartdine.backend.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

@Component
public class DataSeeder {

    @Bean
    CommandLineRunner run(UserRepository userRepository) {
        return args -> {
            if (userRepository.count() == 0) {
                userRepository.save(new User("Phúc", "phuc@example.com"));
                userRepository.save(new User("Linh", "linh@example.com"));
                userRepository.save(new User("Nam", "nam@example.com"));
                System.out.println("Dummy users seeded to Supabase.");
            } else {
                System.out.println("ℹUsers already exist. Skipping seeding.");
            }
        };
    }
}
