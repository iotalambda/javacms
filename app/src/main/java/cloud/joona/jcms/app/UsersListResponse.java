package cloud.joona.jcms.app;

import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;

import java.time.LocalDateTime;
import java.util.stream.Stream;

@Getter
@Setter
@Accessors(chain = true)
public class UsersListResponse {

    private Stream<User> users;

    @Getter
    @Setter
    @Accessors(chain = true)
    public static class User {
        private String username;
        private LocalDateTime created;
    }
}
