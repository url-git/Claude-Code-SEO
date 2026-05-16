export const GitPushNotification = async ({ $ }) => {
  return {
    "tool.execute.after": async (input, output) => {
      if (input.tool === "bash") {
        const command = output.args.command;
        if (command && command.includes("git push")) {
          await $`osascript -e 'display notification "Zmiany wysłane na zdalny serwer" with title "OpenCode" subtitle "git push wykonany" sound name "Glass"'`;
        }
      }
    },
  }
}
