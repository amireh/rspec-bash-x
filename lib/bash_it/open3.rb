require 'open3'

module BashIt
  module Open3
    # an extended version of Open3.popen3 which exposes two pipes for internal
    # communication between the spawned process and ruby
    #
    # the descriptors are available as 62 (child read) and 63 (child write)
    def self.popen3X(*cmd, read_fd: 62, write_fd: 63, &block)
      in_r, in_w = IO.pipe
      out_r, out_w = IO.pipe
      err_r, err_w = IO.pipe
      b2r_r, b2r_w = IO.pipe
      r2b_r, r2b_w = IO.pipe

      opts = {}
      opts[:in] = in_r
      opts[:out] = out_w
      opts[:err] = err_w
      opts[read_fd] = r2b_r
      opts[write_fd] = b2r_w

      env = {
        "BASHIT_R_FD" => "#{read_fd}",
        "BASHIT_W_FD" => "#{write_fd}"
      }

      ::Open3.send(:popen_run,
        [env] + cmd,
        opts,
        [in_r, out_w, err_w, r2b_r, b2r_w], # child_io
        [in_w, out_r, err_r, r2b_w, b2r_r], # parent_io
        &block
      )
    end
  end
end