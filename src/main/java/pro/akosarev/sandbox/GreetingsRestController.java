package pro.akosarev.sandbox;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/greetings")
public class GreetingsRestController {

    @GetMapping
    public ResponseEntity<GreetingsPresentationV1> getGreetings(
            @RequestParam(required = false, defaultValue = "user") String name
    ) {
       return ResponseEntity.ok()
               .contentType(MediaType.valueOf("application/vnd.sandbox.greeting.v1+json"))
               .body(new GreetingsPresentationV1("Hello, %s!".formatted(name)));
    }
}
