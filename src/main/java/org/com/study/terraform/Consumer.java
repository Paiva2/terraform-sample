package org.com.study.terraform;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.awspring.cloud.sqs.annotation.SqsListener;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

import java.util.HashSet;

@Service
public class Consumer {
    private final ObjectMapper objectMapper = new ObjectMapper();

    private final HashSet<TerraformApplication.MessageInput> MEMORY_DB = new HashSet<>();

    @SqsListener(value = "${aws.sqs.queue}")
    public void execute(@Payload String message) {
        try {
            SqsMessageInput messageInput = objectMapper.readValue(message, SqsMessageInput.class);
            TerraformApplication.MessageInput object = objectMapper.readValue(messageInput.getMessage(), TerraformApplication.MessageInput.class);

            MEMORY_DB.add(object);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error while saving new message: ", e);
        }
    }

    public HashSet<TerraformApplication.MessageInput> list() {
        return MEMORY_DB;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class SqsMessageInput {
        @JsonProperty("Type")
        private String type;

        @JsonProperty("MessageId")
        private String messageId;

        @JsonProperty("Message")
        private String message;
    }
}
