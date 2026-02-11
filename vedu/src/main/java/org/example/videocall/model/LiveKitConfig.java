package org.example.videocall.model;

import io.livekit.server.RoomServiceClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class LiveKitConfig {
    @Value("${Livekit_url:http://localhost:7880}")
    private String apiUrl;

    @Value("${LIVEKIT_API_KEY}")
    private String apiKey;

    @Value("${OPENVIDU_SECRET}")
    private String apiSecret;

    @Bean
    public RoomServiceClient roomServiceClient() {
        return RoomServiceClient.create(apiUrl, apiKey, apiSecret);
    }
}
