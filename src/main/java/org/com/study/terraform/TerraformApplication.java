package org.com.study.terraform;

import lombok.AllArgsConstructor;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashSet;

@RestController
@AllArgsConstructor
@SpringBootApplication
public class TerraformApplication {
    private final Publisher publisher;
    private final Consumer consumer;

    public static void main(String[] args) {
        SpringApplication.run(TerraformApplication.class, args);
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return  new ResponseEntity<>("OK", HttpStatus.OK);
    }

    @PostMapping("/pub")
    public ResponseEntity<Void> receive(@RequestBody MessageInput input) {
        publisher.execute(input);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @GetMapping("/sub")
    public ResponseEntity<HashSet<MessageInput>> list() {
        HashSet<MessageInput> messagesList = consumer.list();
        return new ResponseEntity<>(messagesList, HttpStatus.OK);
    }

    public record MessageInput(Integer orderId, String name) {}
}
