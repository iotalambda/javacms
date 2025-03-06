type UsersListResponse = {
  users: { username: string }[];
};

export async function fetchUsersList(): Promise<UsersListResponse> {
  const data = await fetch(`${process.env.JCMS_API_BASE_URL!}/api/users/list`);
  const result = (await data.json()) as UsersListResponse;
  return result;
}
