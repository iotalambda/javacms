import { fetchUsersList } from "@/app/api";

export const dynamic = "force-dynamic";

export default async function Page() {
  const response = await fetchUsersList();
  return (
    <div>
      <ul>
        {response.users.map((u, i) => (
          <li key={i}>{u.username}</li>
        ))}
      </ul>
    </div>
  );
}
