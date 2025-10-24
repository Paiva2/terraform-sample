package org.com.study.terraform;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.awspring.cloud.sns.core.SnsNotification;
import io.awspring.cloud.sns.core.SnsOperations;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class Publisher {
    @Value("${aws.sns.topic}")
    private String SNS_TOPIC;

    private final SnsOperations snsOperations;
    private final ObjectMapper objectMapper;

    public void execute(TerraformApplication.MessageInput input) {
        try {
            log.info("New message received on {}", SNS_TOPIC);
            String message = objectMapper.writeValueAsString(input);

            SnsNotification<String> notification = SnsNotification.builder(message)
                .deduplicationId(input.orderId().toString())
                .groupId(input.name())
                .build();

            snsOperations.sendNotification(SNS_TOPIC, notification);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error while serializing message to sns: ", e);
        }
    }
}
