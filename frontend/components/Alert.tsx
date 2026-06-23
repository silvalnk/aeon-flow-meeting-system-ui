type AlertProps = {
  type?: "success" | "error" | "info";
  message: string;
};

const styles = {
  success: "bg-green-50 border-green-200 text-green-800",
  error: "bg-red-50 border-red-200 text-red-800",
  info: "bg-blue-50 border-blue-200 text-blue-800",
};

export default function Alert({ type = "info", message }: AlertProps) {
  if (!message) return null;
  return (
    <div class={`mb-4 p-4 border rounded-lg ${styles[type]}`}>
      {message}
    </div>
  );
}
