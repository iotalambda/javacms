package cloud.joona.jcms.app;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.stereotype.Repository;

import java.util.stream.Stream;

@Repository
public class UsersRepository {

    @PersistenceContext
    private EntityManager entityMgr;

    public Stream<UserEntity> getAll() {
        return entityMgr
                .createQuery("SELECT username, created FROM Users", UserEntity.class)
                .getResultStream();
    }
}
