package cloud.joona.jcms.app;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UsersController {

    @Autowired
    private UsersRepository usersRepo;

    @GetMapping("/list")
    public ResponseEntity<UsersListResponse> list(
            @RequestHeader Map<String, String> headers,
            HttpServletRequest req) {

        var users = usersRepo.getAll().map(ue -> new UsersListResponse.User()
                .setUsername(ue.getUsername())
                .setCreated(ue.getCreated()));
        var body = new UsersListResponse()
                .setUsers(users);
        return ResponseEntity.ok(body);
    }
}
