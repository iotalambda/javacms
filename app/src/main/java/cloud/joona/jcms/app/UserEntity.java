package cloud.joona.jcms.app;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@Accessors(chain = true)
@Entity(name = "Users")
@Table(name = "ALL_USERS")
public class UserEntity {

    @Id
    @Column(name = "USERNAME")
    private String username;

    @Column(name = "CREATED")
    private LocalDateTime created;
}
